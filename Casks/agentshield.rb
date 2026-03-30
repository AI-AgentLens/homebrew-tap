cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.239"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.239/agentshield_0.2.239_darwin_amd64.tar.gz"
      sha256 "83c17b0c4cd6908b30ec8788a24bb5b820b39ac25dcd169e6194a634b303026b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.239/agentshield_0.2.239_darwin_arm64.tar.gz"
      sha256 "4f2415129952326d72eee99b3e1c0966c86be078024f54776a15495efc2f784e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.239/agentshield_0.2.239_linux_amd64.tar.gz"
      sha256 "b4886c8e09a4c176390c39f753c017d4d43e6d6159254f38cb76d9b2dc6314c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.239/agentshield_0.2.239_linux_arm64.tar.gz"
      sha256 "e960f53134563779e248d5b8dcbea6933fb68b2e2b8c940d748919d767761637"
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
