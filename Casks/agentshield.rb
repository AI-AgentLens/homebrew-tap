cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1071"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1071/agentshield_0.2.1071_darwin_amd64.tar.gz"
      sha256 "c2b906a3c70edb8ec7f5854ab6c17733130c156d66b752a0d4c4e28a8dee148b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1071/agentshield_0.2.1071_darwin_arm64.tar.gz"
      sha256 "0263b1d7de016dd2909ece2db349db19051a19692d8ddde82735ed34cd3508f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1071/agentshield_0.2.1071_linux_amd64.tar.gz"
      sha256 "f23d37611347e81321a0b677eb484ab7fcd0118c11fc46ef320bd4957651bc8e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1071/agentshield_0.2.1071_linux_arm64.tar.gz"
      sha256 "17543722691ccf94d5ad82d542a518ffe15e8b9acd0cccc7bace8d47c0e87b5a"
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
