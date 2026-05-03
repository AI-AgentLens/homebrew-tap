cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.868"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.868/agentshield_0.2.868_darwin_amd64.tar.gz"
      sha256 "639f6b23853698a85ae60e76cfcad6407eaaa10a61f1f6fe3270838a2fe7a706"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.868/agentshield_0.2.868_darwin_arm64.tar.gz"
      sha256 "bbb723505ea09dfa72ccc6d34502125d136608dc3aa3d6a2ae3360098b10e228"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.868/agentshield_0.2.868_linux_amd64.tar.gz"
      sha256 "42674537028d91e0e7bc05f5fffbdab2959707519c9303edf31d79a52e423a91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.868/agentshield_0.2.868_linux_arm64.tar.gz"
      sha256 "4e82ece1f12d2548d982a8a9c82f91fe071f48b3388a05b90e52d9eecfa3abd8"
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
