cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.618"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.618/agentshield_0.2.618_darwin_amd64.tar.gz"
      sha256 "71c299f86c7b73cf9fb84d48618bdf591834f787fbd78344f47c6830667e7063"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.618/agentshield_0.2.618_darwin_arm64.tar.gz"
      sha256 "7d50f65eb1cedc8be3cd7a3c15484abe8df07a623d7a8c46b2704de366ef41b8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.618/agentshield_0.2.618_linux_amd64.tar.gz"
      sha256 "8b91478f9794123f59e191c4967fe050af506223b290922b758e153b8087f69e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.618/agentshield_0.2.618_linux_arm64.tar.gz"
      sha256 "4abfbd9942eda5b739ae0d4962427a5489c69b67f4e05b71954e0d2b8036fa0b"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
