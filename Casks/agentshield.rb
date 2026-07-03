cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1538"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1538/agentshield_0.2.1538_darwin_amd64.tar.gz"
      sha256 "86bb26975599f6b37cfd70dd5b73254d2d57595a1080b1380e3177ec4b60799d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1538/agentshield_0.2.1538_darwin_arm64.tar.gz"
      sha256 "1707719fe456ba5d7872d4c0feb2070ddb663cce1ea0578faf17692410a708dd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1538/agentshield_0.2.1538_linux_amd64.tar.gz"
      sha256 "5b3ed59f7a1a86be9144cf7fd3bdde554b70a09f682b607e8428076b32217f59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1538/agentshield_0.2.1538_linux_arm64.tar.gz"
      sha256 "e4cbdb7338bad0ed2220944b3d3073244150b41b23fbdbca291c9e918e7545c6"
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
