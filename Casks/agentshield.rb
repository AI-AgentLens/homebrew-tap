cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2029"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2029/agentshield_0.2.2029_darwin_amd64.tar.gz"
      sha256 "5c393bf97202b626d7201c6d6bc4816a02ce480f925b9eff9266c4e6e8462246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2029/agentshield_0.2.2029_darwin_arm64.tar.gz"
      sha256 "50f8123af4ad70d6d1d090f0d5eceb7e65630cddeaa1f57612f989ce200b75af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2029/agentshield_0.2.2029_linux_amd64.tar.gz"
      sha256 "abdb8e10811e97460cc162333f7689b3739878d23d99c5f1e3bd07e0ee6472d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2029/agentshield_0.2.2029_linux_arm64.tar.gz"
      sha256 "eeb3adee4f9e6a55c68522ade5f2f288c5d88c6b6a0ac8cc205c8319b1e962df"
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
