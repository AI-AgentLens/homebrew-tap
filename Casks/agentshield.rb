cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1690"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1690/agentshield_0.2.1690_darwin_amd64.tar.gz"
      sha256 "668b08fc52274e465852d94f6284ae65200e781b662179a94987bcc579f618ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1690/agentshield_0.2.1690_darwin_arm64.tar.gz"
      sha256 "b24bed2e9e5b7b5c03ad26a89b2b1f6d25f9a849a83543f728e1d5f7340666c9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1690/agentshield_0.2.1690_linux_amd64.tar.gz"
      sha256 "a362e9fa3c94d317534575a796f161eec8158a6aa59ac54267c90c3db6633e2b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1690/agentshield_0.2.1690_linux_arm64.tar.gz"
      sha256 "31e781e64a3b9f972f891f9b7a25452cc4a307d780fff44665c64ff157110c4b"
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
