cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1331"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1331/agentshield_0.2.1331_darwin_amd64.tar.gz"
      sha256 "4304b1e4b8a0c9116dc85aea9fdf8d9956b21b49ebe05c61165ed0db86bfbb42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1331/agentshield_0.2.1331_darwin_arm64.tar.gz"
      sha256 "e382e151babd2c7e1de9d16ee7e3556b7438dd01cbc7cf55909b45f0bac7796d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1331/agentshield_0.2.1331_linux_amd64.tar.gz"
      sha256 "3ea1201831060d69899ce17361123a24002525d1f119b6db0a68e367a4599fce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1331/agentshield_0.2.1331_linux_arm64.tar.gz"
      sha256 "4f36c8fe5483f69fff2786d56bad1f10b82b02cb9d574335743c67dda1a90f14"
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
