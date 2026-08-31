cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2010"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2010/agentshield_0.2.2010_darwin_amd64.tar.gz"
      sha256 "c8b7181928c676e15823309bc28e2e152bea9f94f45468f4a28de300346bb43e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2010/agentshield_0.2.2010_darwin_arm64.tar.gz"
      sha256 "1c37b0c2a311d531ffc34dc64670103c58943a948d1bcb62bf5627021f25a9fb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2010/agentshield_0.2.2010_linux_amd64.tar.gz"
      sha256 "6ebc5e0cc3d7bb0323c5235f1d92c1887ca3ecd8d2249d409aa7920818a9ce9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2010/agentshield_0.2.2010_linux_arm64.tar.gz"
      sha256 "bdf2bda29518022ed24ae1eb1036e08ddd2e300edd3acf260bbe8129c275ec3a"
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
