cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1509"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1509/agentshield_0.2.1509_darwin_amd64.tar.gz"
      sha256 "46c5ccb1deffccdc7584d1dd581a44ba3436f33ce39625d87deb5e2c206cd404"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1509/agentshield_0.2.1509_darwin_arm64.tar.gz"
      sha256 "2d18982a70fc86eb4daeff5d494c0b3dc8c32e437d6a443ae003cd2dfbcfe0ef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1509/agentshield_0.2.1509_linux_amd64.tar.gz"
      sha256 "7407530a0163b312c8f5b86a8ae1338f081e324a4dac80ff6c74b9cc8cb8255a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1509/agentshield_0.2.1509_linux_arm64.tar.gz"
      sha256 "a171efc87b3ac5d3431c47eebdcde5337b4dedef160840affed78daf30671855"
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
