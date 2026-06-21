cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1390"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1390/agentshield_0.2.1390_darwin_amd64.tar.gz"
      sha256 "66832a70ece7d9970372cc2a2d03e5d59d7e52f751ad6a47cfd4d344232f26cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1390/agentshield_0.2.1390_darwin_arm64.tar.gz"
      sha256 "7472e5475c8934914ef08b6367971956679dfd5953d6e4897cec5eea2ae4889f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1390/agentshield_0.2.1390_linux_amd64.tar.gz"
      sha256 "eb6006eb91baab40c38c0018f55fd8b6d34a583c77c5d93a6d983c17bfe57b77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1390/agentshield_0.2.1390_linux_arm64.tar.gz"
      sha256 "37d22387fd2b3e14525cf23866e072ace6960a70c6a345667a898d3fa0520c4e"
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
