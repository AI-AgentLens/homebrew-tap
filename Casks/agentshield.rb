cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1913"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1913/agentshield_0.2.1913_darwin_amd64.tar.gz"
      sha256 "6250688c17082ad00e9cac3e25f3acb6c01ddda15bcb90777868530d6e17441c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1913/agentshield_0.2.1913_darwin_arm64.tar.gz"
      sha256 "f9d6c12dac2bb417e2f30d8a036ec7c3cb5f0131c052fcaba4f9d8b20af509c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1913/agentshield_0.2.1913_linux_amd64.tar.gz"
      sha256 "7d8491ca5684fbc670e75193c2c960accc1f0dcd8e519b7bf3340ec302d44f39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1913/agentshield_0.2.1913_linux_arm64.tar.gz"
      sha256 "b05007a772cc34f00eb9828708cf6ba24f2288f23729e1505f6d68e151db31b2"
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
