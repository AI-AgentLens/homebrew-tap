cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.718"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.718/agentshield_0.2.718_darwin_amd64.tar.gz"
      sha256 "18bd4f1c94f2248b6c17391931abb77441ec491959e922091cca4d33d02e9ee6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.718/agentshield_0.2.718_darwin_arm64.tar.gz"
      sha256 "3b597e9fe3442eeb714ce648b22fddb688ace8d6bf7b6b2bdcd6e77f845d14f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.718/agentshield_0.2.718_linux_amd64.tar.gz"
      sha256 "9da21d0867a75abab5786fe4a667fbcfd4acaabfe152d04732a52df72a386cbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.718/agentshield_0.2.718_linux_arm64.tar.gz"
      sha256 "1137d4828fa8832e1ae67737740f17435cad57c39c3174a92261e538544149a3"
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
