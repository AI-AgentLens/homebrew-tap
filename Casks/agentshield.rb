cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.587"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.587/agentshield_0.2.587_darwin_amd64.tar.gz"
      sha256 "f96fb6690390feb1dda5c54595ba249891891146caeb32a8367aefb552c4e559"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.587/agentshield_0.2.587_darwin_arm64.tar.gz"
      sha256 "559190bbabcdf6ab30ebe5911c3d754a9b9105d7974a707deafa2bdab662b5d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.587/agentshield_0.2.587_linux_amd64.tar.gz"
      sha256 "1c852b1d6a9f1651bb712785d06493901ca01a5e97e1e06d9f674748a2e72735"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.587/agentshield_0.2.587_linux_arm64.tar.gz"
      sha256 "9534c28cd4a7fb4259baa29e9b9e19f6e794b110354dc06b196d59ec46873af8"
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
