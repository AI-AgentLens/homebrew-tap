cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.313"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.313/agentshield_0.2.313_darwin_amd64.tar.gz"
      sha256 "91f078644fdf656749ed54ff7bf8ae4b17be3cf7563b4ef78a6dba6beadb75d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.313/agentshield_0.2.313_darwin_arm64.tar.gz"
      sha256 "989e2b20ad5cdae71f6a676b60f3bd92fc3ada9659048c2c6f30521192fe8ea0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.313/agentshield_0.2.313_linux_amd64.tar.gz"
      sha256 "b0b2b7bf3cf3f7fded9b9f60c511781c8afba9d5c492ae1423dcae80acb85a78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.313/agentshield_0.2.313_linux_arm64.tar.gz"
      sha256 "c22438755e87fc585926f7d1ae59b480f85d4efe3bcaf8f20657ac376e0d5e40"
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
