cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2012"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2012/agentshield_0.2.2012_darwin_amd64.tar.gz"
      sha256 "eade55da3a118bec84a97c19dc032795c714604b187be00f4fc6b430faae224b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2012/agentshield_0.2.2012_darwin_arm64.tar.gz"
      sha256 "43aec111d17c7aa29e2718db94c7872f19aca5ceba09b1a692808091e32e97fc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2012/agentshield_0.2.2012_linux_amd64.tar.gz"
      sha256 "9d2629375a91e5d52d7be4ccfead163f47475297d5657864ffb3379b44552b5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2012/agentshield_0.2.2012_linux_arm64.tar.gz"
      sha256 "569421fc9d263cba811e243b4d7db8a0411388878638900941a35b005c755942"
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
