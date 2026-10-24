cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2517"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2517/agentshield_0.2.2517_darwin_amd64.tar.gz"
      sha256 "19635f8900aff7c9f1c66bdbdca9e6865e99cffcdec2699b155e6cb46045b04a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2517/agentshield_0.2.2517_darwin_arm64.tar.gz"
      sha256 "172afc97477def33232bd1d61811746ed280ea157c4b6e20a76fb0029839e530"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2517/agentshield_0.2.2517_linux_amd64.tar.gz"
      sha256 "a8438b24cb66885e133b5a0585ad4e85eebb39a7f005660f67a4fe7e7c7ebca5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2517/agentshield_0.2.2517_linux_arm64.tar.gz"
      sha256 "bae0bf28f1a930097e649de415ee6aed2b51b85b4852d6ec3cde95f90bc00c15"
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
