cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.270"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.270/agentshield_0.2.270_darwin_amd64.tar.gz"
      sha256 "f64cfc0e145baa8a022f7ee6f87cc762aebacddb9afbd534257c4c7471a24438"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.270/agentshield_0.2.270_darwin_arm64.tar.gz"
      sha256 "40bcadc2cd72c51abed6d5f9dc788fdd00cbbb18b2c98a248bbe44e2f653b270"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.270/agentshield_0.2.270_linux_amd64.tar.gz"
      sha256 "081796e4ddd4eec26689f94557b6308783a28b478bb5913fb931c8b0e027713f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.270/agentshield_0.2.270_linux_arm64.tar.gz"
      sha256 "820efa493510cde0850b3c03518885d94ce336b07e73e79332b7c47d1b7f7ad0"
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
