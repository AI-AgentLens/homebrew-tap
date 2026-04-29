cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.814"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.814/agentshield_0.2.814_darwin_amd64.tar.gz"
      sha256 "030471851ea6c4d4122d20c5fdfbb8fbdcb902261ec2186ec9c096a9ca16db9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.814/agentshield_0.2.814_darwin_arm64.tar.gz"
      sha256 "c083912afabc651d6f6000240db53073f42355f23fc436a1e3fd517b4a05e718"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.814/agentshield_0.2.814_linux_amd64.tar.gz"
      sha256 "d680e16169c9a9f7c761b9306bd81d56d794b91a76aef034cda9e6a99fdf3600"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.814/agentshield_0.2.814_linux_arm64.tar.gz"
      sha256 "58bf3c718fbb035264b767473166914785202011ccad5d39ac45e825b8a27524"
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
