cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1723"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1723/agentshield_0.2.1723_darwin_amd64.tar.gz"
      sha256 "0cee960c66b427448b6c443719bb0269433bad2c7646c0c90939bb183bdab4e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1723/agentshield_0.2.1723_darwin_arm64.tar.gz"
      sha256 "f7438fcfd5a1211f22c690bb3608f6f70c610fad3114ac15db6c1a83dd4ef78c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1723/agentshield_0.2.1723_linux_amd64.tar.gz"
      sha256 "312b99905d8e2f679c5637f138382226d2a6b73f2045108550013f92eb1f76a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1723/agentshield_0.2.1723_linux_arm64.tar.gz"
      sha256 "06e34d721f96e1e5b5743bcf5c6add2d1147ac7a62e6e7725c39182d4a7d2f22"
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
