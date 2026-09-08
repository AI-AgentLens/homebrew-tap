cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2090"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2090/agentshield_0.2.2090_darwin_amd64.tar.gz"
      sha256 "85e60a1db46f043050e4e1a4dd6c14270c31548e0aa731d9d9ec8bef76ccf35a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2090/agentshield_0.2.2090_darwin_arm64.tar.gz"
      sha256 "3c78ef4d0dfdad04384718159a3bd8a55e0138267848ee06b73108f1109bdd25"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2090/agentshield_0.2.2090_linux_amd64.tar.gz"
      sha256 "360170f4bfaaa0154d619a7d04eac6d4048391ebad4de9278276e05c3d8d722d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2090/agentshield_0.2.2090_linux_arm64.tar.gz"
      sha256 "8d3636ea78cbb9a741738c565dba5467529079cb3262c3e39cc095289a6bc66e"
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
