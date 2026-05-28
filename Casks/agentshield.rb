cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1134"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1134/agentshield_0.2.1134_darwin_amd64.tar.gz"
      sha256 "168a448847977503a6aec6b011bb0e28708778e77c194ab9a61914592fb77181"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1134/agentshield_0.2.1134_darwin_arm64.tar.gz"
      sha256 "c3abda88c7aabaca674a72e8396c0e556a50c902698942efee304bb5caadbe72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1134/agentshield_0.2.1134_linux_amd64.tar.gz"
      sha256 "35d7119041e33423551f457e2263028c238437a3288e0ed1651294c7c4295951"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1134/agentshield_0.2.1134_linux_arm64.tar.gz"
      sha256 "6a52909a81baf40cd827027e025abdab1ba7232ea470285dbf20629f82601530"
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
