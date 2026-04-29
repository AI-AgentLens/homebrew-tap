cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.820"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.820/agentshield_0.2.820_darwin_amd64.tar.gz"
      sha256 "e809dcc9ea4567b1468f353b07d5c4ec4f07aee09307997fd934b3fe2965cc3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.820/agentshield_0.2.820_darwin_arm64.tar.gz"
      sha256 "087c00db813508d82986fdc8470576dea23d6b4a3d578a84a536def101883dd9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.820/agentshield_0.2.820_linux_amd64.tar.gz"
      sha256 "cec04899464ea67451f8835d4bb237584d72421938dd9fc0a6ce72661a99bdfc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.820/agentshield_0.2.820_linux_arm64.tar.gz"
      sha256 "0f104a4fbdd39a26b4a4b5dc75bd2544410832d21ccf01ada4b75bea302a0aa4"
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
