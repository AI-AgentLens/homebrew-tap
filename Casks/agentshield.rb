cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1494"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1494/agentshield_0.2.1494_darwin_amd64.tar.gz"
      sha256 "1119319e9f2f941f666dfcbd6ef10ab094f25b11e44b43dfdaf414efa3eec391"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1494/agentshield_0.2.1494_darwin_arm64.tar.gz"
      sha256 "89efe6b190fd7a01ebddcf02a8ff3f53c8d5d32db987cd0f9d8921c513d8df89"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1494/agentshield_0.2.1494_linux_amd64.tar.gz"
      sha256 "e6af0df5d8afe12e1e938e22d41952253869ee3730a6269a01bef889bf2eb1dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1494/agentshield_0.2.1494_linux_arm64.tar.gz"
      sha256 "0906479dd27afdf5ee7a8926361f0c998812c737adca97a5270fdbfe47c03964"
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
