cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2492"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2492/agentshield_0.2.2492_darwin_amd64.tar.gz"
      sha256 "38e5d72975c0d1e9268028964d71a7baca5b6d4990831545337588f48f26221c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2492/agentshield_0.2.2492_darwin_arm64.tar.gz"
      sha256 "d065de70c0f1d809083825f715b52182377b5d91409b4f21228ca72d7b619791"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2492/agentshield_0.2.2492_linux_amd64.tar.gz"
      sha256 "1118982cff89e37a90358cc7c932086146dc632be0b003abc6643949109c4929"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2492/agentshield_0.2.2492_linux_arm64.tar.gz"
      sha256 "c676d8498d3841f3e2e5dc3e2dac9feafe8d4e3310b6431e26291c8a73b926ef"
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
