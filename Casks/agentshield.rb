cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2491"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2491/agentshield_0.2.2491_darwin_amd64.tar.gz"
      sha256 "7c4e175e1f7c8efc752192b34ad856656a50b1f83d169b20957907bef7634e22"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2491/agentshield_0.2.2491_darwin_arm64.tar.gz"
      sha256 "c6b82b50c293014e7e4c3709ff6563f7a09086bcbadd9c2622221032e02a4b30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2491/agentshield_0.2.2491_linux_amd64.tar.gz"
      sha256 "183d00e22092424922bdf14f51019f9623fbcee84e7c577f6cd7b07e523efaa9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2491/agentshield_0.2.2491_linux_arm64.tar.gz"
      sha256 "de7cf24cd0bac156a367cbfe57c0981bdb2138189dfa7781725acad0509b05ef"
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
