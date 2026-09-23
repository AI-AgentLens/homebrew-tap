cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2234"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2234/agentshield_0.2.2234_darwin_amd64.tar.gz"
      sha256 "18883f9e3d6353b15d17458da2a4ad6f659fbdde392fd4ff91a7dc15830e54d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2234/agentshield_0.2.2234_darwin_arm64.tar.gz"
      sha256 "4917130dfe2c90079f27e1d66bd48e8ea1fd3177eb3aaecb39c9c625a283f5b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2234/agentshield_0.2.2234_linux_amd64.tar.gz"
      sha256 "ec593e0d28e2c3a7dbdb144bc2dd2077f5bf88d6ced83d9c4e070cd5cad16206"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2234/agentshield_0.2.2234_linux_arm64.tar.gz"
      sha256 "d4b9df1d41348d17975de8025bc0fe005bc2175548ade4b25af1bfd0b32d635c"
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
