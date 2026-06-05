cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1212"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1212/agentshield_0.2.1212_darwin_amd64.tar.gz"
      sha256 "36bc44766b3964950ddd3da416fef4fe97225e829a7a5fc4b56d8728c43b9a08"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1212/agentshield_0.2.1212_darwin_arm64.tar.gz"
      sha256 "871b4b766cb23e255f1c2d7468347baab455b7ff0592f76989e78baeeb46c850"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1212/agentshield_0.2.1212_linux_amd64.tar.gz"
      sha256 "f4c04ddacc5d09e43982bfdaf2d1fae9853da7509791a708ab78169eaef66e63"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1212/agentshield_0.2.1212_linux_arm64.tar.gz"
      sha256 "2405e592577c3906657b02a6aa2a23b3fd7e25cefb6b781f52fa954cbb9c9ca3"
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
