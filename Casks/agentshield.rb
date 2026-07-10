cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1605"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1605/agentshield_0.2.1605_darwin_amd64.tar.gz"
      sha256 "aa42d4e414013528f4c9d457c97df5463244fe86eaf48fe24ab46eac290d1cc9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1605/agentshield_0.2.1605_darwin_arm64.tar.gz"
      sha256 "ebb5f881ff5b3fc530978beb7e6bc7973574adf8d650cb2330ee5986ab36d589"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1605/agentshield_0.2.1605_linux_amd64.tar.gz"
      sha256 "baa4bf276b57067c67d148bb8d0ba43ee66809deb33bb8ef5902bdf423c1701d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1605/agentshield_0.2.1605_linux_arm64.tar.gz"
      sha256 "99c8f68b735d86996101dbb0d0991f9a4660e02737fdaa02b2fc501a8bf24e8b"
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
