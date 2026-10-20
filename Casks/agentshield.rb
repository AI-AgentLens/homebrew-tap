cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2479"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2479/agentshield_0.2.2479_darwin_amd64.tar.gz"
      sha256 "adffa7302fb0c8a865b61f18e45e4e1861aab6212e1837255655f100d1afaa96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2479/agentshield_0.2.2479_darwin_arm64.tar.gz"
      sha256 "5a769694fdfa05b0512bdb00e41155f0550fd31a3267d713e0b9d128c5e65b52"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2479/agentshield_0.2.2479_linux_amd64.tar.gz"
      sha256 "4b21b499a3d9f7bab7059b8803adcd82ae098feba61ef3c6f0cfb8fe09f0c515"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2479/agentshield_0.2.2479_linux_arm64.tar.gz"
      sha256 "903f63b571cdb2ffa7c8dc4d4675a79b417caed1f279a79c6aec10297bae725b"
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
