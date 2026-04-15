cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.589"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.589/agentshield_0.2.589_darwin_amd64.tar.gz"
      sha256 "51ae27816669a87ae6a530541373e07399eee010fe1f00df2a1b87c3651b5ab5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.589/agentshield_0.2.589_darwin_arm64.tar.gz"
      sha256 "e1f135fed5babc7ce060f2135e024a42199ee2bcf4cfee6eefba3fc5a079c463"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.589/agentshield_0.2.589_linux_amd64.tar.gz"
      sha256 "2b5934da6ccf5aa433eb8f7026714a23eb5baeda5c940dc1146a2bfe2e62ffec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.589/agentshield_0.2.589_linux_arm64.tar.gz"
      sha256 "a8f1fb2296b7b963d31e05497663f876534868c3e23c336522fda086904543e0"
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

    # Copy community packs to ~/.agentshield/packs/ so the engine can find them
    packs_src = "#{staged_path}/packs"
    if File.directory?(packs_src)
      packs_dst = File.expand_path("~/.agentshield/packs")
      FileUtils.mkdir_p(packs_dst)
      Dir.glob("#{packs_src}/*.yaml").each do |f|
        FileUtils.cp(f, packs_dst)
      end
      # Community MCP packs (already embedded in binary, but copy for visibility)
      mcp_src = "#{packs_src}/community/mcp"
      if File.directory?(mcp_src)
        mcp_dst = File.join(packs_dst, "mcp")
        FileUtils.mkdir_p(mcp_dst)
        Dir.glob("#{mcp_src}/*.yaml").each do |f|
          FileUtils.cp(f, mcp_dst)
        end
      end
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
