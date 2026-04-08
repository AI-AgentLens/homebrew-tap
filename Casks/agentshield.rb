cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.502"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.502/agentshield_0.2.502_darwin_amd64.tar.gz"
      sha256 "79a7cd74fc7402871e7f0d615fc9ce2e47b92c34982878f4c52353f9339a8aaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.502/agentshield_0.2.502_darwin_arm64.tar.gz"
      sha256 "1f67120b06763ced683fca68c9d504ff431f3085c466da75bec583f79983c2d4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.502/agentshield_0.2.502_linux_amd64.tar.gz"
      sha256 "0dfdacb5bb14ac124ec3149cedab6e33e744081f4b9a20c771529b29c4620fd5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.502/agentshield_0.2.502_linux_arm64.tar.gz"
      sha256 "f36a9c4026674668d1dd345aded1ce96560ed7bcb282c44f332ee4b16a8b4c6b"
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
