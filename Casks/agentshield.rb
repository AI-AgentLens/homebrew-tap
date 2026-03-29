cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.182"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.182/agentshield_0.2.182_darwin_amd64.tar.gz"
      sha256 "71d0885c2c0f965f36bb46a9d2aefb8523b59930269416a97b29698577e484aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.182/agentshield_0.2.182_darwin_arm64.tar.gz"
      sha256 "7666d65ea6533f778727ba00aa64d7de70f6f16a8f23d9bf740932aba8f90b55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.182/agentshield_0.2.182_linux_amd64.tar.gz"
      sha256 "985bec159395b3df64b0845b3e45e8a5150a8e1a653f28fd2b5b8b714cc06467"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.182/agentshield_0.2.182_linux_arm64.tar.gz"
      sha256 "89779d8a6b1e4374bea5a7fb0377e6ca75286d8182270f54bc66de1de68166a4"
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
