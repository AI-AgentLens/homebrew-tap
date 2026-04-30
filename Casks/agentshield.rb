cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.823"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.823/agentshield_0.2.823_darwin_amd64.tar.gz"
      sha256 "a5bf4700cdb315a52ab12d7d99179ea9b01c3950a1be3275f4235b9b236a3ae4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.823/agentshield_0.2.823_darwin_arm64.tar.gz"
      sha256 "865a471208a81f0ab979a1c85b2e7f7d61742300464dfd4a3bac5fcbf7af2fb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.823/agentshield_0.2.823_linux_amd64.tar.gz"
      sha256 "077ef59d8be70260660208d1185f474e0a6aa99ed9ca3af7eb48e53ccaf10b23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.823/agentshield_0.2.823_linux_arm64.tar.gz"
      sha256 "6dcec331308141fba65efde76f1c67e3ef49bc801d54749101454c584dd4aa8e"
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
