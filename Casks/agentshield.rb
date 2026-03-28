cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.171"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.171/agentshield_0.2.171_darwin_amd64.tar.gz"
      sha256 "d15a2de2da949e1e8d6c4a803b7abd8f691728583ce479548512eb5aa877065b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.171/agentshield_0.2.171_darwin_arm64.tar.gz"
      sha256 "84cdc69c45956a4f2ee455fbaaafe8a78be2b6aa8cb9b1c3c44ad70a4d12cd8d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.171/agentshield_0.2.171_linux_amd64.tar.gz"
      sha256 "5a3c1f06e7332386d6eaed58f2cfe39b266f6067251fe7ab9b39206e76575889"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.171/agentshield_0.2.171_linux_arm64.tar.gz"
      sha256 "9e0d928ec922c44f089f65c318a9c4cbc6b00e101bc3afb98658527099d944d4"
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
