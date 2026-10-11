cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2404"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2404/agentshield_0.2.2404_darwin_amd64.tar.gz"
      sha256 "68ff180666e7d23d1241c260bbeb5615d22646a5ffc9fd7ac83f794f6cce86ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2404/agentshield_0.2.2404_darwin_arm64.tar.gz"
      sha256 "1c7fea6914bd1ae6ac243a754cf1ed4790130df265792b97f66f0092f07e9dc6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2404/agentshield_0.2.2404_linux_amd64.tar.gz"
      sha256 "efb6d139b268bfdfd73b9cab250ac4570757cfea2ce9e2c48ed0252e1ae63f5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2404/agentshield_0.2.2404_linux_arm64.tar.gz"
      sha256 "ba234d328110241be99e8db8bac64dcce62f1a2eb84af0d6a8f60dc75fecf904"
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
