cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2102"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2102/agentshield_0.2.2102_darwin_amd64.tar.gz"
      sha256 "2d6d9e6b4d45af0d073d2f847aaa851af6339ce7bafb5d864530a5dc914a44b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2102/agentshield_0.2.2102_darwin_arm64.tar.gz"
      sha256 "566a2839ed7c3e85203cd17c71affe819b994d86b588c8acc61e15c685716f63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2102/agentshield_0.2.2102_linux_amd64.tar.gz"
      sha256 "fd4219d21831cc3cfd311be896060dc5e9b73cb544d406756093424b8b3d78f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2102/agentshield_0.2.2102_linux_arm64.tar.gz"
      sha256 "bfe03e26eaaf37931d17e55b5a1a993f7520cfc430135acb21f8509e42aeb6d4"
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
