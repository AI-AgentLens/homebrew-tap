cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.542"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.542/agentshield_0.2.542_darwin_amd64.tar.gz"
      sha256 "7fab6b7bb36627c6917012552330b49ccc355d7219efbfe08c939a92f94a3a27"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.542/agentshield_0.2.542_darwin_arm64.tar.gz"
      sha256 "317edf26b3fd4d28979264341d6e03921240d40e77ba8101c44c7919bbbea7df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.542/agentshield_0.2.542_linux_amd64.tar.gz"
      sha256 "96a1dd7fc26ba13a49a413b95e294bc62cc2798dad38de9adb223b4a8df8543c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.542/agentshield_0.2.542_linux_arm64.tar.gz"
      sha256 "090a942b862a2300f32d65eef6d554cdb2b6eab85db45f54c31ada91dcebe66f"
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
