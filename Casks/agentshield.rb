cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1922"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1922/agentshield_0.2.1922_darwin_amd64.tar.gz"
      sha256 "2ccdde11435519e8836280d9db06b1f0a55b96701b61a72858796539a7fa894b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1922/agentshield_0.2.1922_darwin_arm64.tar.gz"
      sha256 "1b55f508378c1e3aeb5c676f1f431c3faefe5f09f919cd4f7c0f23ede2ff92c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1922/agentshield_0.2.1922_linux_amd64.tar.gz"
      sha256 "73b611c2fe2f765e3fc17978ef27027d58c9bf87c3589f644aafccccb49989f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1922/agentshield_0.2.1922_linux_arm64.tar.gz"
      sha256 "cf521d49f610ee7785ff8f6f1ddacd19012ddb558ddb3935c014b1c3c0dd3a13"
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
