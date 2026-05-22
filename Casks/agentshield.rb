cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1084"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1084/agentshield_0.2.1084_darwin_amd64.tar.gz"
      sha256 "81c56cef51f26ae89f7b455ff9213b767dc57f2320a9ff198688df6113ad62fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1084/agentshield_0.2.1084_darwin_arm64.tar.gz"
      sha256 "aca3db3ac31207ca358165e0946165f118dc6a410a72da10716620b3f7be6936"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1084/agentshield_0.2.1084_linux_amd64.tar.gz"
      sha256 "153be81afd060af0dd849d5ab44f53f10b607993e6f3fd26e98504c0862c2d3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1084/agentshield_0.2.1084_linux_arm64.tar.gz"
      sha256 "ff514292a48e3d23312cde6fb402957e5009e3a9da99be0f31349f41019cd656"
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
