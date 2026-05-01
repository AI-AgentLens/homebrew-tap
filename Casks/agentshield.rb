cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.836"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.836/agentshield_0.2.836_darwin_amd64.tar.gz"
      sha256 "44c55bdcdd7472c672a94b8ead4ad1c338796e35ed8106c8621b7bc1949257cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.836/agentshield_0.2.836_darwin_arm64.tar.gz"
      sha256 "9d8748dc4c5e7e444be5591ef2aa51849301157114e8fece9811e5edd646d17b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.836/agentshield_0.2.836_linux_amd64.tar.gz"
      sha256 "4003291cc6c97aef33561ffdd373a34771473663bb9334880c0e1b565a2161c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.836/agentshield_0.2.836_linux_arm64.tar.gz"
      sha256 "2586f6c6d7d3f25509be629983ea62124ce9d80348a585957b225b7d15d08459"
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
