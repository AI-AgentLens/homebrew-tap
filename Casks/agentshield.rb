cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.705"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.705/agentshield_0.2.705_darwin_amd64.tar.gz"
      sha256 "d77fc96adeb67485daabdcd8de3ad686dfa75ed5931202449393af7a6b7344d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.705/agentshield_0.2.705_darwin_arm64.tar.gz"
      sha256 "9f6db080191fc945d9dc2f7e0fe900117f2e59b9773884ecdbb9c648f9ceb337"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.705/agentshield_0.2.705_linux_amd64.tar.gz"
      sha256 "ebaf3f22dad2940b8619db97393af2e660211da8709cc116771a6bea95b26b97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.705/agentshield_0.2.705_linux_arm64.tar.gz"
      sha256 "f2f336e48a194a693feb95faadbf4115c0aca762a98988cf631e669b4d06028d"
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
