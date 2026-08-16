cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1872"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1872/agentshield_0.2.1872_darwin_amd64.tar.gz"
      sha256 "3ad07730432208c759f518b7fa58734efb6244bf5c8f0b255b4c87f6aa0c519e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1872/agentshield_0.2.1872_darwin_arm64.tar.gz"
      sha256 "cabc2a4438b573e936712343611110247c104b48df6f27fc9fcccea4f0f8c285"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1872/agentshield_0.2.1872_linux_amd64.tar.gz"
      sha256 "bb73f404cfa4cd522c545d4d2f76367befd8b909cbb5c6c7411a11b838227368"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1872/agentshield_0.2.1872_linux_arm64.tar.gz"
      sha256 "f00261d7af844f35538f10ce2b9948fc2a7a19ca7e1ebe0efa317e3f8076c6ff"
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
