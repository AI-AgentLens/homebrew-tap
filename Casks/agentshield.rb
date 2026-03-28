cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.142"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.142/agentshield_0.2.142_darwin_amd64.tar.gz"
      sha256 "c21351226929615254829face7f00a5f966e8369654a854a0f14b6b70a6cb675"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.142/agentshield_0.2.142_darwin_arm64.tar.gz"
      sha256 "7ef9e7462c7c1cd0deb29979c3ef2f5549c9cf14eb62d6d60b396677fe8843c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.142/agentshield_0.2.142_linux_amd64.tar.gz"
      sha256 "15b9cfbbec1735cd70d052d1fe3a51db9dce6a8a2d76215384f8b2b9fe76d6ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.142/agentshield_0.2.142_linux_arm64.tar.gz"
      sha256 "d43988b411daf452f98377bf2b453f8a4391c1c458e7911abeb44a0deef0b14d"
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
