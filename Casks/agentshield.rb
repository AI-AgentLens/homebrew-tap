cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.307"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.307/agentshield_0.2.307_darwin_amd64.tar.gz"
      sha256 "34fcd188c45f309671c4994d244ba3dee5bef847201c632ef509575f4ac64f41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.307/agentshield_0.2.307_darwin_arm64.tar.gz"
      sha256 "fcf0fbc490c7a8252137795f3c5fa5cd98aeadab15ef344fd4b6be245edf8f67"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.307/agentshield_0.2.307_linux_amd64.tar.gz"
      sha256 "b61b735df6c294c09d9543a1c42a32044b19551abf9ccf5e58bb542479f5b1b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.307/agentshield_0.2.307_linux_arm64.tar.gz"
      sha256 "6d8f1136083748a291394a2d4de6a75bf91c1b937369e59ffc661b6a55ea0bec"
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
