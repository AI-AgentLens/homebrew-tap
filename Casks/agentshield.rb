cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.475"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.475/agentshield_0.2.475_darwin_amd64.tar.gz"
      sha256 "93d5612463179cadb603290d6bcf1a7178d9bc2831520abc33ecf4a7d28069b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.475/agentshield_0.2.475_darwin_arm64.tar.gz"
      sha256 "0b6de5a7d6ff68f3ffad812c4f4b4a63a342399eb8ff449f60bb95b19ecc3290"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.475/agentshield_0.2.475_linux_amd64.tar.gz"
      sha256 "9f0b747fb72d164cd62b37ea33e230740b4c3158148135ee881d6cc076b88a44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.475/agentshield_0.2.475_linux_arm64.tar.gz"
      sha256 "1d808bd0fb5f0ce2576b89c0b64aecb243b7d3022cfefe831361e595b9f13373"
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
