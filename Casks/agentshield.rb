cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.447"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.447/agentshield_0.2.447_darwin_amd64.tar.gz"
      sha256 "728b62b0665d6758ddd96f24e154f9790f023a584bb4f0c26e4f32f114995bdc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.447/agentshield_0.2.447_darwin_arm64.tar.gz"
      sha256 "ca2a644ff24d03a949580131853a52d6237bb13fae1a4102a8ee566625880ab5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.447/agentshield_0.2.447_linux_amd64.tar.gz"
      sha256 "5073b571f36a32e3dedd3c400350004b0398cc235cee0b981119702047e72b25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.447/agentshield_0.2.447_linux_arm64.tar.gz"
      sha256 "91d213db6ecc794a0585644a091105fafa03e4b7697f8f4d4ba51ac4a9c0d3bb"
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
