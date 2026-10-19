cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2471"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2471/agentshield_0.2.2471_darwin_amd64.tar.gz"
      sha256 "4378604f6ade4a75e7c854d093ef3f8f3695c26e638e438c2149506d109ecb1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2471/agentshield_0.2.2471_darwin_arm64.tar.gz"
      sha256 "6eb6a7c783bea1bcecea38f40eb9b7ad987364d4133932d9cab4ff429af93843"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2471/agentshield_0.2.2471_linux_amd64.tar.gz"
      sha256 "60f22a14f345e817845480b8a9500be9bf7ec38a44e3dcbd976917bf36e028ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2471/agentshield_0.2.2471_linux_arm64.tar.gz"
      sha256 "9a89096c02b2da7b549805ee9141efddbac1596ece4540ba7a3940e31cf1b788"
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
