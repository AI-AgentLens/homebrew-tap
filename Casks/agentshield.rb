cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1102"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1102/agentshield_0.2.1102_darwin_amd64.tar.gz"
      sha256 "95808b777680c6028857f2c8e604f9b520e2533daeaaa6b970f7b2a838061ac3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1102/agentshield_0.2.1102_darwin_arm64.tar.gz"
      sha256 "e7695e712a02f1e02ef574caa250b420de2e9ac4918fe2867a0dc537e39372b0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1102/agentshield_0.2.1102_linux_amd64.tar.gz"
      sha256 "a3cb8048061001273b32a761becbbbd84fbcfa7b94e2e584e9368fe897f9eb5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1102/agentshield_0.2.1102_linux_arm64.tar.gz"
      sha256 "bcf64fd335ff16aabbe0e25bc3308696b48fe442831e9b4e587aee7a72c6796d"
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
