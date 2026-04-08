cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.495"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.495/agentshield_0.2.495_darwin_amd64.tar.gz"
      sha256 "ac552940eaca676df2ef0803dc52ffc0820562c82cdffba84ab246ba4cead757"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.495/agentshield_0.2.495_darwin_arm64.tar.gz"
      sha256 "f4ccf65cfcc5c9e8c40b3fa714e6ddbc73e6b13b5a0a83104a6f78da56648674"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.495/agentshield_0.2.495_linux_amd64.tar.gz"
      sha256 "40c6b4a7a467a837a5a5ddc56b7fcf11923a1ad468a73cc4d188cd58c4d9a309"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.495/agentshield_0.2.495_linux_arm64.tar.gz"
      sha256 "0f6ed9dc2fd3602e91036caf0af3da2f9e180a8f8f9df5f9e0fe39b7480d8ba2"
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
