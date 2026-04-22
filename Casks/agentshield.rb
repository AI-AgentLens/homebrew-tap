cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.690"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.690/agentshield_0.2.690_darwin_amd64.tar.gz"
      sha256 "59ecd4ca7b1153930d0fe94819f1f1af1ab87be274764a614e6dd1b0741a5486"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.690/agentshield_0.2.690_darwin_arm64.tar.gz"
      sha256 "8fd6e6a0ce055d21e893004c1ef9203f35048edef3e662e16cd8d31df8d44993"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.690/agentshield_0.2.690_linux_amd64.tar.gz"
      sha256 "51fece0254fae7bc59a5f945ffaa37a391dc165787b71645de51c5e395dfa363"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.690/agentshield_0.2.690_linux_arm64.tar.gz"
      sha256 "e557a95b12aee50b1a92c2051246be00f28b9bdca79a8abbcba9f6c3ecd795bb"
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
