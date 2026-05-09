cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.922"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.922/agentshield_0.2.922_darwin_amd64.tar.gz"
      sha256 "8d72d4c38f5cdb6306e268ec69defcfc4e62883cab8b2cc0601ac35df168b935"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.922/agentshield_0.2.922_darwin_arm64.tar.gz"
      sha256 "9ef0dfee9e4c11148a5d8a3cefd99dbee6da89cd9915bae86f78cedcbc89c759"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.922/agentshield_0.2.922_linux_amd64.tar.gz"
      sha256 "9bb1ef3591f935f06a1b8a34a020f5a1c69b3b16abc9a213b4c5e1449c8a6af1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.922/agentshield_0.2.922_linux_arm64.tar.gz"
      sha256 "5e50e1bb7fe410d6a3060a6529441af7f87c722f20e7d09b2e30cba3b2e23506"
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
