cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1935"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1935/agentshield_0.2.1935_darwin_amd64.tar.gz"
      sha256 "4a2873a0bec7d1f0c8a7fea32cb9f670863f033165e73fb64852e0af118d55e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1935/agentshield_0.2.1935_darwin_arm64.tar.gz"
      sha256 "34255ab69b1f02b127f405678463ac01edac444d580a7e9410396786a2389f20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1935/agentshield_0.2.1935_linux_amd64.tar.gz"
      sha256 "6afa76d4bd1411bab86c03bc39988147828ebae966ba8e59509e9080624b8bf3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1935/agentshield_0.2.1935_linux_arm64.tar.gz"
      sha256 "8e06196f29fafd93b538b9e03e7292f69991813df5a4e9c1b4ed6a9ac2f08e7e"
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
