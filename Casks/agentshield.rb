cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.588"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.588/agentshield_0.2.588_darwin_amd64.tar.gz"
      sha256 "c14bf01836f58dc53c09010819332c8a9144967623a69c21d0dc491615a946b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.588/agentshield_0.2.588_darwin_arm64.tar.gz"
      sha256 "d44614913f4b1009c041534b41db0e5ef3e2148b25f8c52fb701010a759ddfca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.588/agentshield_0.2.588_linux_amd64.tar.gz"
      sha256 "dccc472ea98183d9cbc2368a7e2a2eb1058f0c674408fd991e42a654906be25c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.588/agentshield_0.2.588_linux_arm64.tar.gz"
      sha256 "e6642677ef63b5c5f402882b6d14133e7c9748519229c0d0c271e690d402c827"
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
