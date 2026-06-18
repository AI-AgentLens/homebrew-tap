cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1363"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1363/agentshield_0.2.1363_darwin_amd64.tar.gz"
      sha256 "5d20b82a5570dfe010b72923b8bc22f47ed39f93d8df196a2be89daf2a95b124"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1363/agentshield_0.2.1363_darwin_arm64.tar.gz"
      sha256 "90b6b3f2777e1ab9a3cf98b607647cc77523173442c8cba51aa57f4236a4d0b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1363/agentshield_0.2.1363_linux_amd64.tar.gz"
      sha256 "f52ba912f09f967b38aeb1b4148d4611f6b79ecb87d3cb96e9c072c58d581c8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1363/agentshield_0.2.1363_linux_arm64.tar.gz"
      sha256 "43ae1c47887e62126a378bd6eb427fd7382308b41a740be784cd90a228169307"
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
