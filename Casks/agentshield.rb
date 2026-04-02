cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.292"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.292/agentshield_0.2.292_darwin_amd64.tar.gz"
      sha256 "0b2cb6e18433ca00cf99c2d8422e4b152f0e6ec068d3334562bf7e289e7eaa38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.292/agentshield_0.2.292_darwin_arm64.tar.gz"
      sha256 "731f5006660b54f67856b85637c5cc0eae3efc8170c0986505c8855722ef4880"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.292/agentshield_0.2.292_linux_amd64.tar.gz"
      sha256 "8312033eb32fad4151291fe7838c55747a11fc021f9253fbac3978710fd30112"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.292/agentshield_0.2.292_linux_arm64.tar.gz"
      sha256 "d9b079f27185f1b7fa1382853e19eeef30258af1b8fd67b16c958c7a01f634b3"
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
